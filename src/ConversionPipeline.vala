/* ConversionPipeline.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.ConversionPipeline : Object {
    private GenericArray<Transform> transformations = new GenericArray<Transform> ();

    public bool configured { get; private set; }
    public File image_directory { get; private set; }

    public Format source { get; private set; }
    public Format target { get; private set; }

    public void configure (Format source, Format target, RequiredTransformations required_transforms) {
        this.source = source;
        this.target = target;
    }

    private void configure_lookup_images (Format source, Format target) {
    }
}