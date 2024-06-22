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
        if (!(annotation.class_name in table)) {
            throw new TransformError.NO_MAPPING (@"$(annotation.class_name) does not have a corresponding value in the map provided");
        }
        annotation.class_name = table[annotation.class_name];
    }
}