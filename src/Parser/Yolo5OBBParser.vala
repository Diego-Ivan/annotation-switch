/* Yolo5OBBParser.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Yolo5OBBParser : Object, AnnotationSwitch.FormatParser {
    private File source_directory = null;
    private FileEnumerator enumerator = null;
    private FileInfo? next_info = null;
    private DataInputStream? current_stream = null;

    public void init (File source) throws GLib.Error {
        if (source.query_file_type (NOFOLLOW_SYMLINKS, null) != DIRECTORY) {
            throw new FileError.WRONG_SOURCE ("The source must be a directory");
        }

        enumerator = source.enumerate_children ("standard::*", NOFOLLOW_SYMLINKS, null);
        source_directory = source;
    }

    public Annotation? get_next () throws Error 
    requires (current_stream != null) {
        var annotation = new Annotation ();

        string line = current_stream.read_line (null, null);
        
        if (line == null) {
            return null;
        }

        string[] elements = line.split(" ");
        if (elements.length < 9) {
            throw new ParseError.WRONG_FORMAT (@"Line: '$line'. Expected 9-10 parameters, got $(elements.length)");
        }

        /* Parsing it as float, as some implementations use floating point numbers */
        var coordinates = new float[8];
        for (int i = 0; i < coordinates.length; i++) {
            float coord;
            if (!float.try_parse (elements[i], out coord, null)){
                throw new ParseError.WRONG_FORMAT (@"Line: '$line'. Expected number at position $i but got $(elements[i])");
            }
            coordinates[i] = coord;
        }

        annotation.source_file = next_info.get_name ().replace (".txt", ".png");
        annotation.class_name = elements[8];

        annotation.x_min = (int) Math.fminf (
            Math.fminf (coordinates[0], coordinates[2]), 
            Math.fminf (coordinates[4], coordinates[6])
        );

        annotation.x_max = (int) Math.fmaxf (
            Math.fmaxf (coordinates[0], coordinates[2]), 
            Math.fmaxf (coordinates[4], coordinates[6])
        );

        annotation.y_min = (int) Math.fminf (
            Math.fminf (coordinates[1], coordinates[3]), 
            Math.fminf (coordinates[5], coordinates[7])
        );

        annotation.y_max = (int) Math.fmaxf (
            Math.fmaxf (coordinates[1], coordinates[3]), 
            Math.fmaxf (coordinates[5], coordinates[7])
        );

        return annotation;
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
        message (@"Returning $(info.get_name ())");
        return info;
    }
}