import sublime_plugin

class KeepMultiCursorsInViewListener(sublime_plugin.EventListener):

    def on_post_text_command(self, view, command_name, args):
        sel = view.sel()
        if len(sel) > 1:
            if 'forward' in args and ((command_name in ('move', 'smart_cursor') and args.get('by') == 'lines') or command_name in ('select_lines')):
                view.show(sel[-1 if args['forward'] else 0], False)
