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
 *
 * The inputs to this class are expected to not be normalized. As an option, there are methods to normalize and denormalize with respect
 * to the given image proportions. The only annotations that are normalized are the ones returned from this class.
 */
[Compact (opaque = true)]
public class AnnotationSwitch.Annotation {
    public string source_file { get; set; default = ""; }
    public string image { get; set; default = null; }
    public string class_name { get; set; default = null; }
    public string class_id { get; set; default = null; }

    public int difficulty { get; set; default = 0; }
    
    public double x1 { get; set; default = 0; }
    public double y1 { get; set; default = 0; }
    public double x2 { get; set; default = 0; }
    public double y2 { get; set; default = 0; }
    public double x3 { get; set; default = 0; }
    public double y3 { get; set; default = 0; }
    public double x4 { get; set; default = 0; }
    public double y4 { get; set; default = 0; }

    public Annotation (double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
        this.x4 = x4;
        this.y4 = y4;
    }

    public Annotation.from_centers (double center_x, double center_y, double width, double height) {
        double distance_x = width / 2.0;
        double distance_y = height / 2.0;

        double x1, y1, x2, y2, x3, y3, x4, y4;
        x1 = x3 = center_x - distance_x;
        x2 = x4 = center_x + distance_x;

        y1 = y2 = center_y - distance_y;
        y3 = y4 = center_y - distance_y;

        this (x1, y1, x2, y2, x3, y3, x4, y4);
    }

    public Annotation.from_min_max (double x_min, double y_min, double x_max, double y_max) {
        this (x_min, y_min, x_max, y_min, x_max, y_max, x_min, y_max);
    }

    public string to_string () {
        return @"x1: $x1, y1: $y1, x2: $x2, y2: $y2, x3: $x3, y3: $y3, x4: $x4, y4: $y4. Class Name: $class_name. Source: $source_file. Source Image: $image";
    }

    public double compute_x_max () {
        return Math.fmax (
            Math.fmax (x1, x2),
            Math.fmax (x3, x4)
        );
    }

    public double compute_x_min () {
        return Math.fmin (
            Math.fmin (x1, x2),
            Math.fmin (x3, x4)
        );
    }

    public double compute_y_max () {
        return Math.fmax (
            Math.fmax (y1, y2),
            Math.fmax (y3, y4)
        );
    }

    public double compute_y_min () {
        return Math.fmin (
            Math.fmin (y1, y2),
            Math.fmin (y3, y4)
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