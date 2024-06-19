/* FormatSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface AnnotationSwitch.FormatSerializer {
    public abstract void init (File destination) throws GLib.Error;
    public abstract void push (Annotation annotation) throws GLib.Error;
    public abstract void finish () throws GLib.Error;
}