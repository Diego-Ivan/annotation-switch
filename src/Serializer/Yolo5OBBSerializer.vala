/* Yolo5OBBSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Yolo5OBBSerializer : AnnotationSwitch.FormatSerializer {
    private File destination = null;
    public void init (File destination) throws GLib.Error {
        FileInfo destination_info = destination.query_info ("standard::*", NOFOLLOW_SYMLINKS, null);
        if (destination_info.get_file_type () != DIRECTORY) {
            throw new AnnotationSwitch.Error.WRONG_DESTINATION ("The destination must be a directory");
        }
    }

    public void push (Annotation annotation) throws GLib.Error {
    }

    public void finish () throws GLib.Error {
    }
}