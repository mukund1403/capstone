# 2026-03-01T16:37:49.931298300
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_hls")

comp = client.get_component(name="hls_component")
comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="PACKAGE")

vitis.dispose()

vitis.dispose()

