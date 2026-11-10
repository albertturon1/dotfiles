# Model tiers (this machine)

Read by the `delegate` skill. Keep one line per tier; edit the model IDs when models change.

- cheap: preferred GLM 5.3 flash High, otherwise providerInstanceId=claudeAgent model=claude-haiku-5-5 effort=high;
- standard: providerInstanceId=claudeAgent model=claude-sonnet-5-5 effort=medium
- strong: providerInstanceId=claudeAgent model=claude-opus-5-5 effort=high
