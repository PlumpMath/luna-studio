LunaEditorTab = require './luna-editor-tab'
LunaStudioTab = require './luna-studio-tab'
SubAtom       = require 'sub-atom'

(require './luna-visualizers')()
codeEditor = (require './gen/text-editor-ghcjs.js')()
nodeEditor = (require './gen/node-editor-ghcjs.js')()
path = require 'path'
LunaSemanticGrammar = require './luna-grammar'


pushShortcutEvent = (name, arg = null) -> nodeEditor.pushEvent({_shortcut: name, _arg : arg})
pushSearcherEvent = (name, arg = null) -> nodeEditor.pushEvent(if arg == null then {tag: name} else {tag: name, contents : arg})

module.exports = LunaStudio =

  deserializeLunaEditorTab: ({uri}) ->
    actStatus = (status) ->
        if status == 'activate'
            codeEditor.pushInternalEvent(event: "OpenFile", uri: uri)
            atom.workspace.getActivePane().activateItem new LunaEditorTab(uri, codeEditor)

    codeEditor.statusListener actStatus


  deserializeLunaStudioTab: ({uri}) ->
    actStatus = (status) ->
      if uri != null
          if status == 'activate'
              codeEditor.pushInternalEvent(event: "OpenFile", uri: uri)
              new LunaStudioTab(uri, nodeEditor)
    codeEditor.statusListener actStatus

  activate: (state) ->
    atom.grammars.addGrammar(new LunaSemanticGrammar(atom.grammars, codeEditor.lex))
    codeEditor.connect(nodeEditor.connector)
    codeEditor.start()
    actStatus = (data) ->
        if data == 'activate'
            rootPath = atom.project.getPaths().shift()
            if rootPath != ""
                codeEditor.pushInternalEvent(event: "SetProject", uri: rootPath)
            atom.workspace.getActivePane().activateItem new LunaStudioTab(null, nodeEditor)
    codeEditor.statusListener actStatus



    atom.workspace.addOpener (uri) ->

      if path.extname(uri) is '.luna'
          codeEditor.pushInternalEvent(event: "OpenFile", uri: uri)
          new LunaEditorTab(uri, codeEditor)
    @subs = new SubAtom

    @subs.add atom.workspace.onDidChangeActivePaneItem (items) ->
        if items instanceof LunaEditorTab
            nodeEditor.pushEvent(tag: "SetFile", path: items.uri)


    @subs.add atom.workspace.onDidDestroyPaneItem (event) =>
        if (event.item instanceof LunaEditorTab)
            uris = (pane.uri for pane in atom.workspace.getPaneItems())
            if event.item.uri not in uris
                nodeEditor.pushEvent(tag: "UnsetFile")
                return codeEditor.pushInternalEvent(event: "CloseFile", uri: event.item.uri)

    @subs.add atom.workspace.observeTextEditors (editor) ->
      editor.onDidSave (e) =>
          if path.extname(e.path) is ".luna"
              atom.workspace.destroyActivePaneItem()
              codeEditor.pushInternalEvent(event: "OpenFile", uri: e.path)
              atom.workspace.getActivePane().activateItem new LunaEditorTab(e.path, codeEditor)
              codeEditor.pushInternalEvent(event: "SaveFile", uri: e.path)


    @subs.add atom.commands.add 'atom-text-editor', 'core:copy': ->
        if atom.workspace.getActivePaneItem() instanceof LunaEditorTab
            activeFilePath = atom.workspace.getActivePaneItem().buffer.file.path
            buffer = atom.workspace.getActiveTextEditor().buffer
            selection = atom.workspace.getActiveTextEditor().getSelections()
            spanList = ({start: buffer.characterIndexForPosition(s.marker.oldHeadBufferPosition), stop: buffer.characterIndexForPosition(s.marker.oldTailBufferPosition)} for s in selection)
            codeEditor.pushInternalEvent(event: "Copy", uri: activeFilePath, selections: spanList)

    @subs.add atom.commands.add 'atom-workspace', 'core:close', (e) ->
        if (atom.workspace.getActivePaneItem() instanceof LunaStudioTab)
            e.preventDefault()
            e.stopImmediatePropagation()

    @subs.add atom.commands.add 'atom-workspace', 'core:close': ->
        if (atom.workspace.getActivePaneItem() instanceof LunaEditorTab) or (atom.workspace.getActivePaneItem() instanceof LunaStudioTab)
            uris = (pane.uri for pane in atom.workspace.getPaneItems())
            if atom.workspace.getActivePaneItem().uri not in uris
                nodeEditor.pushEvent(tag: "UnsetFile")
                return codeEditor.pushInternalEvent(event: "CloseFile", uri: atom.workspace.getActivePaneItem().uri)

    @subs.add atom.commands.add 'atom-workspace', 'core:save', (e)                 ->
      if (atom.workspace.getActivePaneItem() instanceof LunaEditorTab) or (atom.workspace.getActivePaneItem() instanceof LunaStudioTab)
          e.preventDefault()
          e.stopImmediatePropagation()
          codeEditor.pushInternalEvent(event: "SaveFile", uri: atom.workspace.getActivePaneItem().uri)



    @subs.add atom.commands.add '.luna-studio', 'core:cancel':              -> pushShortcutEvent("Cancel")
    # camera
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:center-graph': -> pushShortcutEvent("CenterGraph")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:pan-down':     -> pushShortcutEvent("PanDown")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:pan-left':     -> pushShortcutEvent("PanLeft")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:pan-right':    -> pushShortcutEvent("PanRight")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:pan-up':       -> pushShortcutEvent("PanUp")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:reset-camera': -> pushShortcutEvent("ResetCamera")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:reset-pan':    -> pushShortcutEvent("ResetPan")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:reset-zoom':   -> pushShortcutEvent("ResetZoom")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:zoom-in':      -> pushShortcutEvent("ZoomIn")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:zoom-out':     -> pushShortcutEvent("ZoomOut")
    # clipboard
    @subs.add atom.commands.add '.luna-studio', 'core:copy':  -> pushShortcutEvent("Copy")
    @subs.add atom.commands.add '.luna-studio', 'core:cut':   -> pushShortcutEvent("Cut")
    @subs.add atom.commands.add '.luna-studio', 'core:paste': -> pushShortcutEvent("Paste", atom.clipboard.read())
    # navigation
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:exit-graph':    -> pushShortcutEvent("ExitGraph")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-cone-down':  -> pushShortcutEvent("GoConeDown")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-cone-left':  -> pushShortcutEvent("GoConeLeft")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-cone-right': -> pushShortcutEvent("GoConeRight")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-cone-up':    -> pushShortcutEvent("GoConeUp")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-down':       -> pushShortcutEvent("GoDown")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-left':       -> pushShortcutEvent("GoLeft")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-next':       -> pushShortcutEvent("GoNext")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-prev':       -> pushShortcutEvent("GoPrev")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-right':      -> pushShortcutEvent("GoRight")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:go-up':         -> pushShortcutEvent("GoUp")
    # nodes
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:autolayout-all-nodes':        -> pushShortcutEvent("AutolayoutAllNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:autolayout-selected-nodes':   -> pushShortcutEvent("AutolayoutSelectedNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:close-visualization-preview': -> pushShortcutEvent("CloseVisualizationPreview")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:collapse-to-function':        -> pushShortcutEvent("CollapseToFunction")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:edit-selected-nodes':         -> pushShortcutEvent("EditSelectedNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:expand-selected-nodes':       -> pushShortcutEvent("ExpandSelectedNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:open-visualization-preview':  -> pushShortcutEvent("OpenVisualizationPreview")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:remove-selected-nodes':       -> pushShortcutEvent("RemoveSelectedNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:select-all':                  -> pushShortcutEvent("SelectAll")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:unfold-selected-nodes':       -> pushShortcutEvent("UnfoldSelectedNodes")
    @subs.add atom.commands.add '.luna-studio', 'luna-studio:zoom-visualization':          -> pushShortcutEvent("ZoomVisualization")
    # searcher
    @subs.add atom.commands.add '.luna-studio',   'luna-studio:searcher-open':         -> pushShortcutEvent("SearcherOpen")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-0':     -> pushSearcherEvent("HintShortcut", 0)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-1':     -> pushSearcherEvent("HintShortcut", 1)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-2':     -> pushSearcherEvent("HintShortcut", 2)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-3':     -> pushSearcherEvent("HintShortcut", 3)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-4':     -> pushSearcherEvent("HintShortcut", 4)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-5':     -> pushSearcherEvent("HintShortcut", 5)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-6':     -> pushSearcherEvent("HintShortcut", 6)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-7':     -> pushSearcherEvent("HintShortcut", 7)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-8':     -> pushSearcherEvent("HintShortcut", 8)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-9':     -> pushSearcherEvent("HintShortcut", 9)
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept-input': -> pushSearcherEvent("AcceptInput")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-accept':       -> pushSearcherEvent("Accept")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-tab-pressed':  -> pushSearcherEvent("TabPressed")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-move-down':    -> pushSearcherEvent("MoveDown")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-move-left':    -> pushSearcherEvent("MoveLeft")
    @subs.add atom.commands.add '.luna-searcher', 'luna-studio:searcher-move-up':      -> pushSearcherEvent("MoveUp")
    # undo/redo
    @subs.add atom.commands.add '.luna-studio', 'core:redo': -> pushShortcutEvent("Redo")
    @subs.add atom.commands.add '.luna-studio', 'core:undo': -> pushShortcutEvent("Undo")

  deactivate: ->
    @subs.dispose()