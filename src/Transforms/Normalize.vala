/* Normalize.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.Normalize : Transform {
    public File image_directory { get; set; default = null; }

    public Normalize (File image_directory) {
        this.image_directory = image_directory;
    }

    public override void apply (Format source, Format target, Annotation annotation) throws Error {
        File image_file = image_directory.resolve_relative_path (annotation.image);
        var image_pixbuf = new Gdk.Pixbuf.from_file (image_file.get_path ());

        annotation.x1 /= image_pixbuf.width;
        annotation.x2 /= image_pixbuf.width;
        annotation.x3 /= image_pixbuf.width;
        annotation.x4 /= image_pixbuf.width;

        annotation.y1 /= image_pixbuf.height;
        annotation.y2 /= image_pixbuf.height;
        annotation.y3 /= image_pixbuf.height;
        annotation.y4 /= image_pixbuf.height;
    }
}