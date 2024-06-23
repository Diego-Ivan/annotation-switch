/* ClassMapping.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.ClassMapping : Transform {
    public HashTable<string, string> table { get; set; }

    public ClassMapping (HashTable<string, string> table) {
        this.table = table;
    }

    public override void apply (Format source, Format target, Annotation annotation) throws Error {
        switch (target.class_format) {
        // Means the source has been found to use class id and must converto class id
        case ID:
            map_id_from_name (annotation);
            break;
        
        // Means the source has been found to use ids and must convert to class name
        case NAME:
            map_name_from_id (annotation);
            break;

        case BOTH:
            /* If the target class does not have class name, it must be mapped from the id */
            if (annotation.class_name == null) {
                map_name_from_id (annotation);
            } else {
                /* Otherwise, the id must be mapped from the name */
                map_id_from_name (annotation);
            }
            /* If both are null, an error will be thrown */
            break;
        }
    }

    private void map_id_from_name (Annotation annotation) throws Error{
        if (!(annotation.class_name in table)) {
            throw new TransformError.NO_MAPPING (@"$(annotation.class_name) does not have a corresponding value in the map provided");
        }
        annotation.class_id = table[annotation.class_name];
    }

    private bool map_name_from_id (Annotation annotation) {
        if (!(annotation.class_id in table)) {
            return false;
        }
        annotation.class_name = table[annotation.class_id];
        return true;
    }
}