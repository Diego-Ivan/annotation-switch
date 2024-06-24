/* FormatRegistry.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[SingleInstance]
public class AnnotationSwitch.FormatRegistry : Object {
    private HashTable <string, Format> formats;

    protected static FormatRegistry? instance = null;
    public static FormatRegistry get_instance () {
        if (instance == null) {
            instance = new FormatRegistry ();
        }
        return instance;
    }

    [CCode (has_construct_function = false)]
    protected FormatRegistry () {}

    construct {
        formats = new HashTable <string, Format> (string.hash, str_equal);

        formats["yolo5obb"] = new Format ("Yolo v5 Oriented Bounding Boxes", "yolo5obb") {
            parser_type = typeof (Yolo5OBBParser), serializer_type = typeof (Yolo5OBBSerializer),
            file_extension = "txt", contains_image_path = false, named_after_image = true,
            is_normalized = false, class_format = NAME, source_type = FOLDER
        };

        formats["oidv4"] = new Format ("OID v4", "oidv4") {
            parser_type = typeof (OIDv4Parser), serializer_type = typeof (OIDv4Serializer),
            file_extension = "txt", contains_image_path = false, named_after_image = true,
            is_normalized = false, class_format = NAME, source_type = FOLDER
        };

        formats["coco"] = new Format ("COCO JSON", "coco") {
            parser_type = typeof (OIDv4Parser),
            file_extension = "json", contains_image_path = true, named_after_image = false,
            is_normalized = true, class_format = ID, source_type = FILE, contains_mapping = true,
        };
    }

    public Format? get_from_id (string id) {
        if (!(id in formats)) {
            critical (@"The Registry does not contain a format with id $id");
            return null;
        }
        return formats[id];
    }

    public FormatSerializer? get_serializer_for_id (string id) {
        Format? format = get_from_id (id);
        if (format == null) {
            return null;
        }
        if (format.serializer_type == Type.INVALID) {
            critical (@"Format: $(format.name) with id $id does not have a serializer registered");
            return null;
        }
        return (FormatSerializer) Object.new (format.serializer_type);
    }

    public FormatParser? get_parser_for_id (string id) {
        Format? format = get_from_id (id);
        if (format == null) {
            return null;
        }
        if (format.parser_type == Type.INVALID) {
            critical (@"Format: $(format.name) with id $id does not have a parser registered");
        }

        return (FormatParser) Object.new (format.parser_type);
    }

    public ListModel get_formats_with_parser () {
        var store = new ListStore (typeof (Format));
        foreach (Format format in formats.get_values ()) {
            if (format.parser_type != Type.INVALID) {
                store.append (format);
            }
        }
        return store;
    }

    public ListModel get_formats_with_serializer () {
        var store = new ListStore (typeof (Format));
        foreach (Format format in formats.get_values ()) {
            if (format.serializer_type != Type.INVALID) {
                store.append (format);
            }
        }
        return store;
    }
}