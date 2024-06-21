annotation_switch_sources = [
  '../vapi/config.vapi',
  'main.vala',
  'application.vala',
  'window.vala',

  'ErrorDomains.vala',

  # Widgets
  'Widgets/FormatSourceRow.vala',

  # Models
  'Models/Format.vala',
  'Models/Annotation.vala',

  # Parser
  'Parser/FormatParser.vala',
  'Parser/Yolo5OBBParser.vala',
  'Parser/OIDv4Parser.vala',

  # Serializer
  'Serializer/FormatSerializer.vala',
  'Serializer/Yolo5OBBSerializer.vala',
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

conf = configuration_data()
conf.set_quoted('APP_ID', 'io.github.diegoivan.annotation_switch')
conf.set_quoted('APP_NAME', 'Annotation Switch')
conf.set_quoted('G_LOG_DOMAIN', 'Annotation Switch')
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf.set_quoted('GNOMELOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

annotation_switch_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
  m_dep,
]

gnome = import('gnome')
blueprint_compiler = find_program('blueprint-compiler')

blueprints = files (
  'ui/window.blp',
  'ui/format-source-row.blp',
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
