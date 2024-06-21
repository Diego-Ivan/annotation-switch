/* FormatSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface AnnotationSwitch.FormatSerializer : Object {
    public abstract void init (File destination, HashTable<string, string>? mapping) throws GLib.Error;
    public abstract void push (owned Annotation annotation);
    public abstract void finish () throws GLib.Error;
}