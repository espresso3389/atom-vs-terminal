exec = require('child_process').exec
path = require('path')
platform = require('os').platform
env = require('process').env
fs = require('fs')

if platform() != 'win32'
    return

openOnFolder = (folder,bat,arg,title) ->
    cmd = env['ComSpec']
    cmdline = "\"#{cmd}\" /K \"#{bat}\" #{arg}"
    console.log(cmdline)
    exec "start \"#{title}\" " + cmdline, cwd: folder if folder?

openForFile = (file,bat,arg,title) ->
    dirpath = path.dirname(file)
    cmd = env['ComSpec']
    cmdline = "\"#{cmd}\" /K \"#{bat}\" #{arg}"
    console.log("#{cmdline} on #{dirpath}")
    exec "start \"#{title}\" " + cmdline, cwd: dirpath if dirpath?

openForActivePane = (bat,arg,title) ->
    editor = atom.workspace.getActivePaneItem()
    openForFile(editor?.buffer?.file?.path,bat,arg,title)

module.exports =
    activate: ->
        v2n = {
            '100': 'VS2010'
            '110': 'VS2012'
            '120': 'VS2013'
            '140': 'VS2015'}
        menues = []
        for vsver, vsname of v2n
            vstooldir = env['VS'+vsver+'COMNTOOLS']
            vcvarsall = vstooldir + '..\\..\\VC\\vcvarsall.bat'
            if fs.existsSync(vcvarsall)
                for arch in ['x86', 'amd64']
                    cmd = "visual-studio-terminals:#{vsname}-#{arch}";
                    label = vsname + " (#{arch})"
                    menues.push { label: label, command: cmd }
                    atom.commands.add "atom-workspace", cmd, => openForActivePane(vcvarsall, arch, label)
        atom.contextMenu.add {
            'atom-workspace': [{
                label: 'Visual Studio Terminals',
                submenu: menues
            }]
        }
