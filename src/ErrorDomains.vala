/* ErrorDomains.vala
 *
 * Copyright 2024 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public errordomain AnnotationSwitch.FileError {
    WRONG_DESTINATION,
    WRONG_SOURCE
}

public errordomain AnnotationSwitch.ParseError {
    WRONG_FORMAT,
    NO_MAPPINGS,
}

public errordomain AnnotationSwitch.SerializeError {
    FAILED_TO_WRITE,
}