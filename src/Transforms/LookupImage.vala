/* LookupImage.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class AnnotationSwitch.LookupImage : Transform {
    public File directory { get; set; }
    private HashTable<string, string> source_to_image;
    private GenericSet<string> sources_without_image;

    public LookupImage (File directory) {
        this.directory = directory;
        source_to_image = new HashTable<string, string> (string.hash, str_equal);
        sources_without_image = new GenericSet<string> (string.hash, str_equal);
    }

    public override void apply (Format source, Format target, Annotation annotation) throws Error {
        if (annotation.source_file in sources_without_image) {
            throw new TransformError.NO_IMAGE (@"No corresponding image for $(annotation.source_file) in directory $(directory.get_path ())");
        }

        if (annotation.source_file in source_to_image) {
            annotation.image = source_to_image[annotation.source_file];
            return;
        }

        bool found = false;
        FileEnumerator enumerator = directory.enumerate_children ("standard::name", NOFOLLOW_SYMLINKS, null);
        FileInfo? info = null;

        while ((info = enumerator.next_file (null)) != null) {
            if (info.get_name ().has_prefix (annotation.source_file)) {
                found = true;
                source_to_image[annotation.source_file] = info.get_name ();
            }
        }

        if (!found) {
            sources_without_image.add (annotation.source_file);
            throw new TransformError.NO_IMAGE (@"No corresponding image for $(annotation.source_file) in directory $(directory.get_path ())");
        }
    }
}

public class AnnotationSwitch.ChangeExtension : Transform {
    public override void apply (Format source, Format target, Annotation annotation) throws Error {
        with (annotation) {
            source_file = source_file.replace (source.file_extension, target.file_extension);
        }
    }
}

public class AnnotationSwitch.FromImageExtension : Transform {
    public override void apply (Format source, Format target, Annotation annotation) throws Error {
    }
}