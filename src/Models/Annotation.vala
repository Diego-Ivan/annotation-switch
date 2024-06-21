/* Annotation.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * A class that represents an annotation that uses oriented bounding boxes
 *
 * The class supports computing the oriented bounding box to normal bounding boxes,
 * of course with a loss of information as consequence.
 */
[Compact (opaque = true)]
public class AnnotationSwitch.Annotation {
    public string source_file { get; set; default = ""; }
    public string image { get; set; default = ""; }
    public string class_name { get; set; default = ""; }
    
    public Position position1 { get; private set; }
    public Position position2 { get; private set; }
    public Position position3 { get; private set; }
    public Position position4 { get; private set; }

    public Annotation (double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
        position1 = new Position (x1, y1);
        position2 = new Position (x2, y2);
        position3 = new Position (x3, y3);
        position4 = new Position (x4, y4);
    }

    public string to_string () {
        return @"Position 1: $position1, Position 2: $position2, Position 3: $position3, Position 4: $position4. Class Name: $class_name. Source: $source_file. Source Image: $image";
    }

    public double compute_x_max () {
        return Math.fmax (
            Math.fmax (position1.x, position2.x),
            Math.fmax (position3.x, position4.x)
        );
    }

    public double compute_x_min () {
        return Math.fmin (
            Math.fmin (position1.x, position2.x),
            Math.fmin (position3.x, position4.x)
        );
    }

    public double compute_y_max () {
        return Math.fmax (
            Math.fmax (position1.y, position2.y),
            Math.fmax (position3.y, position4.y)
        );
    }

    public double compute_y_min () {
        return Math.fmin (
            Math.fmin (position1.y, position2.y),
            Math.fmin (position3.y, position4.y)
        );
    }

    public double compute_width () {
        return compute_x_max () - compute_x_min ();
    }

    public double compute_height () {
        return compute_y_max () - compute_y_min ();
    }

    public double compute_x_center () {
        return (compute_x_max () + compute_x_min ()) / 2.0;
    }

    public double compute_y_center () {
        return (compute_y_max () + compute_y_min ()) / 2.0;
    }
}

[Compact]
public class AnnotationSwitch.Position {
    public double x;
    public double y;

    public Position (double x, double y) {
        this.x = x;
        this.y = y;
    }

    public string to_string () {
        return @"x: $x, y: $y";
    }
}