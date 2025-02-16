/* Yolo5OBBSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Yolo5OBBSerializer : Object, AnnotationSwitch.FormatSerializer {
    private File destination = null;
    private HashTable<string, GenericArray<Annotation>> annotation_map;

    public void init (File destination) throws GLib.Error {
        FileInfo destination_info = destination.query_info ("standard::*", NOFOLLOW_SYMLINKS, null);
        if (destination_info.get_file_type () != DIRECTORY) {
            throw new AnnotationSwitch.FileError.WRONG_DESTINATION ("The destination must be a directory");
        }
        this.destination = destination;
        annotation_map = new HashTable<string, GenericArray<Annotation>> (string.hash, str_equal);
    }

    public void push (owned Annotation annotation) {
        if (!(annotation.source_file in annotation_map)) {
            annotation_map[annotation.source_file] = new GenericArray<Annotation> ();
        }

        GenericArray<Annotation> image_annotations = annotation_map[annotation.source_file];
        image_annotations.add ((owned) annotation);
    }
    public void finish () throws GLib.Error {
        foreach (string source_file in annotation_map.get_keys ()) {
            File text_file = destination.resolve_relative_path (source_file);

            write_to_file (text_file, annotation_map[source_file]);
        }
    }

    private void write_to_file (File file, GenericArray<Annotation> annotations) throws Error {
        var output_stream = FileStream.open (file.get_path (), "w");
        if (output_stream == null) {
            throw new SerializeError.FAILED_TO_WRITE (@"Failed to write to $(file.get_path ()), could not open a FileStream");
        }

        foreach (unowned Annotation annotation in annotations) {
            double x1 = annotation.x1, x2 = annotation.x2, 
                x3 = annotation.x3, x4 = annotation.x4,
                y1 = annotation.y1, y2 = annotation.y2,
                y3 = annotation.y3, y4 = annotation.y4;

            string format = @"$x1 $y1 $x2 $y2 $x3 $y3 $x4 $y4 $(annotation.class_name) 0\n";
            output_stream.write (format.data);
        }
    }
}