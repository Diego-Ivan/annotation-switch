/* CocoParser.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.CocoParser : FormatParser, Object {
    private File? json_file = null;
    private Json.Array annotation_array = null;
    private uint current_position = -1;

    private HashTable<int, string> category_map;
    private HashTable<int, string> image_map;

    public Annotation? get_next () throws Error {
        Json.Object? object = annotation_array.get_object_element (current_position);
        if (object == null) {
            throw new ParseError.WRONG_FORMAT (@"Expected element at $current_position in the annotation array to be an object");
        }

        Json.Node? category_id_node = object.get_member ("category_id");
        if (category_id_node.get_node_type () != VALUE) {
            throw new ParseError.WRONG_FORMAT (
                @"Expected member id of element at $current_position to be a value, but got $(category_id_node.get_node_type ())"
            );
        }

        int category_id = (int) category_id_node.get_int ();
        if (!(category_id in category_map)) {
            throw new ParseError.NO_MAPPINGS (@"Id $category_id of element at $current_position is not in the category map");
        }

        string class_name = category_map[category_id];

        Json.Node? image_id_node = object.get_member ("image_id");
        if (image_id_node.get_node_type () != VALUE) {
            throw new ParseError.WRONG_FORMAT ("Element image_id of element at $current_position is not a value");
        }

        int image_id = (int) image_id_node.get_int ();
        if (!(image_id in image_map)) {
            throw new ParseError.NO_MAPPINGS (@"Image id $image_id does not have a corresponding image");
        }

        string image_name = image_map[image_id];

        Json.Array? bbox = object.get_array_member ("bbox");
        if (bbox == null) {
            throw new ParseError.WRONG_FORMAT (@"BBox array missing at element $current_position in the annotation array");
        }
        if (bbox.get_length () != 4) {
            throw new ParseError.WRONG_FORMAT (@"Bbox element (position: $current_position) requires length 4");
        }

        double center_x = bbox.get_double_element (0), center_y = bbox.get_double_element (1),
            width = bbox.get_double_element (2), height = bbox.get_double_element (3);
        
        return new Annotation.from_centers (center_x, center_y, width, height) {
            class_name = class_name,
            class_id = @"$category_id",
            source_file = json_file.get_path (),
            image = image_name
        };
    }

    public void init (GLib.File source) throws Error {
        if (source.query_file_type (NOFOLLOW_SYMLINKS, null) != REGULAR) {
            throw new FileError.WRONG_SOURCE (@"The file $(source.get_path ()) must be a regular file");
        }

        FileInfo file_info = source.query_info ("standard::*", NOFOLLOW_SYMLINKS, null);
        if (file_info.get_content_type () != "application/json") {
            throw new FileError.WRONG_SOURCE (@"The file $(source.get_path ()) must be JSON document");
        }

        json_file = source;

        var json_parser = new Json.Parser ();
        json_parser.load_from_file (json_file.get_path ());
    
        Json.Node root_node = json_parser.get_root ();
        Json.Object? object = root_node.get_object ();

        if (object == null) {
            throw new ParseError.WRONG_FORMAT (@"Expected root note to be an object, but got $(root_node.get_node_type ())");
        }

        annotation_array = object.get_array_member ("annotations");
        if (annotation_array == null) {
            throw new ParseError.WRONG_FORMAT (@"Root object does not contain the 'annotations' array");
        }

        Json.Array? category_array = object.get_array_member ("categories");
        if (category_array == null) {
            throw new ParseError.WRONG_FORMAT (@"Root object does not contain 'categories' array member");
        }

        Json.Array? images_array = object.get_array_member ("images");
        if (images_array == null) {
            throw new ParseError.WRONG_FORMAT (@"Root object does not contain 'images' array member");
        }
        
        category_map = parse_category_map (category_array);
        message ("Starting to parse images");
        image_map = parse_image_map (images_array);
    }

    private HashTable<int, string> parse_category_map (Json.Array categories) throws Error {
        var table = new HashTable<int, string> (direct_hash, direct_equal);
        for (int i = 0; i < categories.get_length (); i++) {
            Json.Object category = categories.get_object_element (i);
            if (category == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected element $i in the category array to be an object.");
            }

            if (!category.has_member ("id")) {
                throw new ParseError.WRONG_FORMAT (@"Element id in the object $i of the category array was not found");
            }

            Json.Node id_node = category.get_member ("id");
            if (id_node.get_node_type () != VALUE) {
                throw new ParseError.WRONG_FORMAT (@"Expected element id to be a value type, but got $(id_node.get_node_type ())");
            }
            int id = (int) id_node.get_int ();

            if (!category.has_member ("name")) {
                throw new ParseError.WRONG_FORMAT (@"Element name in the object $id of the category array was not found");
            }
            Json.Node name_node = category.get_member ("name");
            string? name = name_node.get_string ();

            if (name == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected element name to be a value type, but got $(id_node.get_node_type ())");
            }

            table[id] = name;
        }
        return (owned) table;
    }

    private HashTable<int, string> parse_image_map (Json.Array image_array) throws Error {
        var table = new HashTable<int, string> (direct_hash, direct_equal);
        for (int i = 0; i < image_array.get_length (); i++) {
            Json.Object image_object = image_array.get_object_element (i);
            if (image_object == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected $i element in 'images' array to be an object");
            }

            Json.Node? id_node = image_object.get_member ("id");
            if (id_node == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected member id of $i element in 'images' array");
            }
            if (id_node.get_node_type () != VALUE) {
                throw new ParseError.WRONG_FORMAT (@"Expected member id of $i element in 'images' array to be a value, but got $(id_node.get_node_type ())");
            }

            int id = (int) id_node.get_int ();

            Json.Node? filename_node = image_object.get_member ("file_name");
            if (filename_node == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected member file_name of $i element in 'images' array");
            }
            string? file_name = filename_node.get_string ();
            if (file_name == null) {
                throw new ParseError.WRONG_FORMAT (@"Expected file_name member of $i element in 'images' array to be a string");
            }

            table[id] = file_name;
        }
        return (owned) table;
    }

    public bool has_next () {
        current_position += 1;
        return current_position < annotation_array.get_length ();
    }
}