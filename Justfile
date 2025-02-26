repo := "fast-90/oryx-with-custom-qmk"
workflow := "'Fetch and build layout'"
filename := "voyager_9jOaj"
download_dir := "~/Downloads"

# Build and download QMK firmware
default: build download

[private]
ls:
    @just --list

# Build the QMK firmware with Github Workflow
build $LESS='FRX':
    #!/usr/bin/env sh
    gh workflow run {{workflow}} -R {{repo}}
    
    echo "⏳ Waiting 2 min before polling completion."
    sleep 120

    while [ "$(gh run list -R {{repo}} --workflow={{workflow}} --json conclusion -q '.[0].conclusion')" != "success" ]; do
        echo "Waiting for the Github build workflow to complete..."
        sleep 5
    done
    echo "Build completed!"
    echo "Pulling in potential Oryx changes..."
    git pull

# Download the QMK firmware binary created by the last workflow run
download:
    #!/usr/bin/env sh
    gh run list -R {{repo}} --workflow={{workflow}} --limit 1 --json databaseId -q '.[].databaseId' | while read run_id; do
        gh run download $run_id -R {{repo}} -n {{filename}} --dir {{download_dir}}
    done
    echo "✅ Downloaded {{filename}} to {{download_dir}}."
