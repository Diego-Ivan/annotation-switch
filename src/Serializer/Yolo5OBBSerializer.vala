/* Yolo5OBBSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Yolo5OBBSerializer : Object, AnnotationSwitch.FormatSerializer {
    private File destination = null;
    private HashTable<string, GenericArray<Annotation>> annotation_map;
    private HashTable<string, string>? mapping;

    public void init (File destination, HashTable<string, string>? mapping) throws GLib.Error {
        FileInfo destination_info = destination.query_info ("standard::*", NOFOLLOW_SYMLINKS, null);
        if (destination_info.get_file_type () != DIRECTORY) {
            throw new AnnotationSwitch.FileError.WRONG_DESTINATION ("The destination must be a directory");
        }
        this.destination = destination;
        this.mapping = mapping;

        annotation_map = new HashTable<string, GenericArray<Annotation>> (string.hash, str_equal);
    }

    public void push (owned Annotation annotation) {
        if (!(annotation.image in annotation_map)) {
            annotation_map[annotation.image] = new GenericArray<Annotation> ();
        }

        GenericArray<Annotation> image_annotations = annotation_map[annotation.image];
        image_annotations.add ((owned) annotation);
    }
    public void finish () throws GLib.Error {
        foreach (string image in annotation_map.get_keys ()) {
            string text_name = image.replace (".png", ".txt");
            File text_file = destination.resolve_relative_path (text_name);

            write_to_file (text_file, annotation_map[image]);
        }
    }

    private void write_to_file (File file, GenericArray<Annotation> annotations) throws Error {
        var output_stream = FileStream.open (file.get_path (), "w");
        if (output_stream == null) {
            throw new SerializeError.FAILED_TO_WRITE (@"Failed to write to $(file.get_path ()), could not open a FileStream");
        }

        foreach (unowned Annotation annotation in annotations) {
            string class_name = null;
            if (mapping != null) {
                class_name = mapping[annotation.class_name];
            }

            if (class_name == null) {
                class_name = annotation.class_name;
            }

            double x1 = annotation.position1.x, x2 = annotation.position2.x, 
                x3 = annotation.position3.x, x4 = annotation.position4.x,
                y1 = annotation.position1.y, y2 = annotation.position2.y,
                y3 = annotation.position3.y, y4 = annotation.position4.y;

            string format = @"$x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4 $class_name 0\n";
            output_stream.write (format.data);
        }
    }
}