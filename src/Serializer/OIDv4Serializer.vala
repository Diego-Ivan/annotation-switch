/* FormatParser.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.OIDv4Serializer : FormatSerializer, Object {
    private File destination = null;
    private HashTable<string, GenericArray<Annotation>> annotation_map;

    public void init (File destination) throws Error {
        if (destination.query_file_type (NOFOLLOW_SYMLINKS, null) != DIRECTORY) {
            throw new FileError.WRONG_DESTINATION ("The destination must be a directory");
        }
        this.destination = destination;
        annotation_map = new HashTable<string, GenericArray<Annotation>> (string.hash, str_equal);
    }
    public void push (owned Annotation annotation) {
        if (!(annotation.source_file in annotation_map)) {
            annotation_map[annotation.source_file] = new GenericArray<Annotation> ();
        }

        var array = annotation_map[annotation.source_file];
        array.add ((owned) annotation);
    }
    public void finish () throws Error {
        foreach (string file_path in annotation_map.get_keys ()) {
            File text_file = destination.resolve_relative_path (file_path);
            write_to_file (text_file, annotation_map[file_path]);
        }
    }

    private void write_to_file (File file, GenericArray<Annotation> annotations) throws Error {
        FileStream? stream = FileStream.open (file.get_path (), "w");
        if (stream == null) {
            throw new SerializeError.FAILED_TO_WRITE (@"Could not open FileStream for $(file.get_path ())");
        }
                              
        /*  
         * The format looks like this:
         *   name_of_the_class    left    top     right     bottom
         *
         *   (Origin in top left corner)
         *   left x, top y                        
         *   ╔═════════════════════════╗      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ║                         ║      
         *   ╚═════════════════════════╝      
         *               right x, bottom y  
         * Which means left = x_min, right = x_max, top = min_y, bottom = max_y
         */
 
        foreach (unowned Annotation annotation in annotations) {
            double left = annotation.compute_x_min (),
                right = annotation.compute_x_max (),
                top = annotation.compute_y_min (),
                bottom = annotation.compute_y_max ();
            
            string format = @"$(annotation.class_name) $left $top $right $bottom\n";
            stream.write (format.data);
        }
    }
}