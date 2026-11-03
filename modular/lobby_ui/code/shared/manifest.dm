/datum/preferences/proc/show_banda_manifest(mob/user, manifest_html)
	if(!uses_banda_terminal_interface() || !istext(manifest_html))
		return FALSE

	var/html = get_banda_auxiliary_window_header("МАНИФЕСТ ПЕРСОНАЛА", "ТЕКУЩИЙ СОСТАВ ЭКИПАЖА", "banda-manifest-window")
	html += "<div class='banda-manifest-data prefs-no-translate'>[manifest_html]</div>"
	html += {"
		[get_banda_terminal_styles("manifest")]
	"}
	html += {"
		<script>
			(function() {
				var rows = document.querySelectorAll('table.manifest tr');
				for (var index = 0; index < rows.length; index++) {
					var row = rows.item(index);
					row.className += ' manifest-row-loading';
					row.style.animationDelay = Math.min(index * 35, 1200) + 'ms';
				}
			})();
		</script>
	"}
	html += get_banda_auxiliary_window_footer()
	show_browser(user, html, "Манифест персонала", "manifest", width = 760, height = 750)
	return TRUE
