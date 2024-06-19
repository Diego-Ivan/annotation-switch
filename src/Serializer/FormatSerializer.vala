/* FormatSerializer.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface AnnotationSwitch.FormatSerializer {
    public abstract void init (File destination) throws AnnotationSwitch.Error;
}