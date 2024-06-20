/* Annotation.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/* TODO: Better support for Oriented Bounding Boxes */

[Compact (opaque = true)]
public class AnnotationSwitch.Annotation {
    public string source_file { get; set; default = ""; }
    public string image { get; set; default = ""; }
    public string class_name { get; set; default = ""; }
    public int x_min { get; set; default = -1; }
    public int y_min { get; set; default = -1; }
    public int x_max { get; set; default = -1; }
    public int y_max { get; set; default = -1; }

    public string to_string () {
        return @"x min: $x_min, y min: $y_min, x max: $x_max y max: $y_max, class: $class_name, source: $source_file";
    }
}