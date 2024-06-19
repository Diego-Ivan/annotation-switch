/* Annotation.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Annotation {
    public string source_file { get; set; default = ""; }
    public int x_min { get; set; default = -1; }
    public int y_min { get; set; default = -1; }
    public int x_max { get; set; default = -1; }
    public int y_max { get; set; default = -1; }
}