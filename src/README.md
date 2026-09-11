# src/ — espelho do código Luau do place

Exportado do Studio via MCP (ver `skills/checkpoint-and-backup.md`). **A verdade viva é o place**;
este espelho existe para leitura, revisão e diff. Ao alterar um script pelo Studio, reexporte.

Convenção de nomes: `.server.lua` = `Script`, `.client.lua` = `LocalScript`, `.lua` = `ModuleScript`.
O caminho reflete a hierarquia do DataModel.

```
ReplicatedStorage/Shared/        MovementConfig · InventoryConfig · SoundConfig · DialogueConfig
ServerScriptService/             MovementServer · InventoryServer · SoundServer · TriggerServer
StarterPlayer/StarterPlayerScripts/
                                 MovementController · CameraEffects · MovementAudio · InventoryController
                                 FootstepController · LightFlicker · InteractionPrompts
                                 CarriedLightController · DialogueController · MazeEntryController
ServerStorage/Items/             ToggleOnActivate (LocalScript dentro das Tools Lanterna e Lampião)
```

Não exportados (são da Roblox): `RbxCharacterSounds`, `StarterCharacter/Animate`.

Instâncias sem código que fazem parte da arquitetura (GUIs, RemoteEvents, pastas, marcadores, tags e
atributos) estão descritas em `docs/03-arquitetura.md`. Se um dia o projeto migrar para Rojo, esta
pasta já está no formato certo para virar `default.project.json`.
