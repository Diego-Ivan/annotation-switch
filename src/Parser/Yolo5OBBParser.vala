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

    public void init (File source) throws GLib.Error {
        if (source.query_file_type (NOFOLLOW_SYMLINKS, null) != DIRECTORY) {
            throw new AnnotationSwitch.Error.WRONG_SOURCE ("The source must be a directory");
        }

        enumerator = source_directory.enumerate_children ("standard::*", NOFOLLOW_SYMLINKS, null);
    }

    public Annotation? get_next () 
    requires (next_info != null) {
        var annotation = new Annotation ();
        return annotation;
    }
    
    public bool has_next () {
        try {
            next_info = enumerator.next_file (null);
        } catch (GLib.Error e) {
            warning (e.message);
        }
        return next_info != null;
    }
}