# 2026-02-20T10:32:47.696230300
import vitis

client = vitis.create_client()
client.set_workspace(path="hardware")

comp = client.create_hls_component(name = "hls_component",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

comp = client.get_component(name="hls_component")
comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

