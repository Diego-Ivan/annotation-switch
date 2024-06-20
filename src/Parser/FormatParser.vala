/* FormatParser.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface AnnotationSwitch.FormatParser : Object {
    public abstract void init (File source) throws GLib.Error;
    public abstract Annotation? get_next ();
    public abstract bool has_next ();
}