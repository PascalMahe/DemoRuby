:: very silent install to custom dir with file associations and PATH update
:: (cf. https://github.com/oneclick/rubyinstaller/wiki/faq#wiki-silent_install)
rubyinstaller-2.0.0-p195-x64.exe /verysilent /dir="\Dev\Ruby200-x64" /tasks="assocfiles,modpath"
:: rubyinstaller-1.9.3-p448.exe /verysilent /dir="\Dev\Ruby193" /tasks="assocfiles,modpath"