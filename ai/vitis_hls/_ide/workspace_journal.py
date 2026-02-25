# 2026-02-25T12:49:03.740835800
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_hls")

comp = client.get_component(name="hls_component")
comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

