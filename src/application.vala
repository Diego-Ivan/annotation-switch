/* application.vala
 *
 * Copyright 2024 Diego Iván
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace AnnotationSwitch {
    public class Application : Adw.Application {
        public Application () {
            Object (application_id: "io.github.diegoivan.annotation_switch", flags: ApplicationFlags.DEFAULT_FLAGS);
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new AnnotationSwitch.Window (this);
            }
            win.present ();
        }

        private void on_about_action () {
            string[] developers = { "Diego Iván M.E" };
            var about = new Adw.AboutWindow () {
                transient_for = this.active_window,
                application_name = "Annotation Switch",
                application_icon = "io.github.diegoivan.annotation_switch",
                copyright = "© 2024 Diego Iván M.E",
                developer_name = "Diego Iván M.E",
                developers = developers,
                license_type = GPL_3_0,
                // translators: Write your name<email> here :D
                translator_credits = _("translator_credits"),
                version = Config.VERSION,
            };

            about.present ();
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
