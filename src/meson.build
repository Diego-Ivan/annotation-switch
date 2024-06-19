annotation_switch_sources = [
  'main.vala',
  'application.vala',
  'window.vala',

  'ErrorDomains.vala',

  # Models
  'Models/Format.vala',
  'Models/Annotation.vala',

  # Parser
  'Parser/FormatParser.vala',
  'Parser/Yolo5OBBParser.vala',

  # Serializer
  'Serializer/FormatSerializer.vala',
  'Serializer/Yolo5OBBSerializer.vala',
]

annotation_switch_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

gnome = import('gnome')
blueprint_compiler = find_program('blueprint-compiler')

blueprints = files (
  'ui/window.blp',
)

resource_file = files('annotation-switch.gresource.xml')
annotation_switch_resources = gnome.compile_resources('flowtime-resources',
  resource_file,
  c_name: 'annotation_switch',
  dependencies: custom_target(
    build_always_stale: true,
    command: [blueprint_compiler, 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
    input: blueprints,
    output: '.',
  ),
)

annotation_switch_sources += annotation_switch_resources

executable('annotation-switch', annotation_switch_sources,
  dependencies: annotation_switch_deps,
  vala_args: [
    '--gresourcesdir=src/',
  ],
       install: true,
)
