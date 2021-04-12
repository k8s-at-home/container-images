#!/usr/bin/env bash

read -r -a ideRunnerCandidates <<< "$(grep -lr --include=*.sh com.intellij.idea.Main /app)"

if [[ ${#ideRunnerCandidates[@]} != 1 ]]; then
    echo "Can't find a single candidate to be IDE runner script so can't select a single one:"
    echo "${ideRunnerCandidates[*]}"
    exit 1
fi

export IDE_RUN_FILE_NAME=${ideRunnerCandidates[0]/".sh"/""}

echo "Found IDE: $IDE_RUN_FILE_NAME"

cp "$IDE_RUN_FILE_NAME.sh" "$IDE_RUN_FILE_NAME-projector.sh"

# change `classpath "$CLASSPATH"` to `classpath "$CLASSPATH:$IDE_HOME/projector-server/lib/*"`
# shellcheck disable=SC2016
sed -i 's+classpath "$CLASSPATH"+classpath "$CLASSPATH:/app/projector-server/lib/*"+g' "$IDE_RUN_FILE_NAME-projector.sh"

# change `com.intellij.idea.Main` to `-Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher`
sed -i 's+com.intellij.idea.Main+-Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher+g' "$IDE_RUN_FILE_NAME-projector.sh"

# create/replace idea.properties
export XDG_CONFIG_HOME=/config
PV=$(grep -oP 'PRODUCT_VENDOR="\K(.*)(?=\"$)' "$IDE_RUN_FILE_NAME-projector.sh")
PS=$(grep -oP 'PATHS_SELECTOR="\K(.*)(?=\"$)' "$IDE_RUN_FILE_NAME-projector.sh")
P="${XDG_CONFIG_HOME}/${PV}/${PS}"
mkdir -p "$P"

echo "Updating IDE preferences"
cp /tmp/idea.properties "${P}/idea.properties"
