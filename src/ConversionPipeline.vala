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

    public bool configured { get; private set; default = false; }
    public File image_directory { get; set; }
    public HashTable<string, string> class_map { get; set; }

    public File conversion_source { get; set; }
    public File conversion_target { get; set; }

    public Format source { get; construct; }
    public Format target { get; construct; }

    public ConversionPipeline (Format source, Format target) {
        Object (source: source, target: target);
    }

    public void convert () 
    requires (source != null)
    requires (target != null)
    requires (conversion_source != null)
    requires (conversion_target != null)
    requires (configured) {
        var registry = FormatRegistry.get_instance ();
        FormatParser? parser = registry.get_parser_for_id (source.id);
        FormatSerializer? serializer = registry.get_serializer_for_id (target.id);

        if (parser == null) {
            critical (@"Format $(source.name) is missing a parser");
            return;
        }

        if (serializer == null) {
            critical (@"Format $(target.name) is missing a serializer");
            return;
        }

        try {
            parser.init (conversion_source);
            serializer.init (conversion_target);
        } catch (Error e) {
            critical (e.message);
            return;
        }

        message ("Starting conversion");

        while (parser.has_next ()) {
            try {
                Annotation annotation = parser.get_next ();
                print (@"$annotation\n");
                serializer.push ((owned) annotation);
            } catch (Error e) {
                warning (e.message);
            }
        }

        try {
            serializer.finish ();
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void configure (RequiredTransformations required_transforms) throws Error 
    requires (source != null)
    requires (target != null) {
        if (source.named_after_image && target.named_after_image) {
            transformations.add (new ChangeExtension ());
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

        if (NAME_TO_ID in required_transforms || ID_TO_NAME in required_transforms) {
            if (class_map == null) {
                throw new PipelineError.MISSING_REQUIREMENTS (@"Mapping is required to transform from $(source.name) to $(target.name)");
            }
            transformations.add (new ClassMapping (class_map));
        }

        configured = true;
    }
}