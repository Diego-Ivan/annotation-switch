/* Transform.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public abstract class AnnotationSwitch.Transform {
    public abstract void apply (Format source, Format target, Annotation annotation) throws Error;
}

public errordomain AnnotationSwitch.TransformError {
    NO_IMAGE,
}

[Flags]
public enum AnnotationSwitch.RequiredTransformations {
    NORMALIZE,
    DENORMALIZE,
    LOOKUP_IMAGE,
    ID_TO_NAME,
    NAME_TO_ID;

    public string to_string () {
        return FlagsClass.to_string (typeof (RequiredTransformations), this);
    }
}