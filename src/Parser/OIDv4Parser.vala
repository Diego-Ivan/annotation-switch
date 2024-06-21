/* OIDv4Parser.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.OIDv4Parser : FormatParser, Object {
    private File source_directory = null;
    private FileEnumerator enumerator = null;
    private FileInfo? next_info = null;
    private DataInputStream? current_stream = null;

    public void init (GLib.File source) throws Error {
        if (source_directory.query_file_type (NOFOLLOW_SYMLINKS, null) != DIRECTORY) {
            throw new FileError.WRONG_DESTINATION ("Destination must be a directory");
        }
        source_directory = source;
    }

    public Annotation? get_next () throws Error 
    requires (current_stream != null) {
        string line = current_stream.read_line (null, null);
        
        if (line == null) {
            return null;
        }

        string[] elements = line.split(" ");
        if (elements.length < 5) {
            throw new ParseError.WRONG_FORMAT (@"Line: '$line'. Expected 5 elements, got $(elements.length)");
        }

        /* Parsing it as float, as some implementations use floating point numbers */
        var coordinates = new float[4];
        for (int i = 0; i < coordinates.length; i++) {
            float coord;
            if (!float.try_parse (elements[i + 1], out coord, null)) {
                throw new ParseError.WRONG_FORMAT (@"Line: $line. Expected number, got $(elements[i + 1])");
            }
            coordinates[i] = coord;
        }

        return new Annotation.from_min_max (coordinates[0], coordinates[3], coordinates[2], coordinates[1]) {
            class_name = elements[0]
        };
    }
    
    public bool has_next () {
        if (current_stream != null && current_stream.get_available () > 0) {
            return true;
        }

        if (current_stream == null || current_stream?.get_available () <= 0) {
            next_info = look_for_next_text_file ();
            if (next_info == null) {
                return false;
            }
        }

        File text_file = source_directory.resolve_relative_path (next_info.get_name ());
        try {
            current_stream?.close (null);
            current_stream = new DataInputStream (text_file.read (null));
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return current_stream != null;
    }

    private FileInfo? look_for_next_text_file () {
        FileInfo? info = null;
        try {
            while ((info = enumerator.next_file (null)) != null) {
                if (info.get_content_type () == "text/plain") {
                    break;
                }
            }
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return info;
    }
}