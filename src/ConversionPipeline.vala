/* ConversionPipeline.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public errordomain AnnotationSwitch.PipelineError {
    MISSING_REQUIREMENTS,
}

public class AnnotationSwitch.ConversionPipeline : Object {
    private GenericArray<Transform> transformations = new GenericArray<Transform> ();

    public bool configured { get; private set; }
    public File image_directory { get; private set; }

    public Format source { get; private set; }
    public Format target { get; private set; }

    public void configure (Format source, Format target, RequiredTransformations required_transforms) throws Error {
        this.source = source;
        this.target = target;

        if (source.named_after_image && target.named_after_image) {
            transformations.add (new ChangeExtension ());
            return;
        }

        if (LOOKUP_IMAGE in required_transforms) {
            if (image_directory == null) {
                throw new PipelineError.MISSING_REQUIREMENTS (@"Image directory is required to transform from $(source.name) to $(target.name), but none was provided");
            }
            transformations.add (new LookupImage (image_directory));
        }

        if (NORMALIZE in required_transforms) {
            if (image_directory == null) {
                throw new PipelineError.MISSING_REQUIREMENTS (@"Image directory is required to transform from $(source.name) to $(target.name), but none was provided");
            }
            transformations.add (new Normalize (image_directory));
        }

        if (DENORMALIZE in required_transforms) {
            if (image_directory == null) {
                throw new PipelineError.MISSING_REQUIREMENTS (@"Image directory is required to transform from $(source.name) to $(target.name), but none was provided");
            }
            transformations.add (new Denormalize (image_directory));
        }
    }
}