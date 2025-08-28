{
  description = "Vulkan Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        lib = nixpkgs.lib;
        pkgs = import nixpkgs {
          system = "${system}";
          config = {
            allowUnfree = true;
            nvidia.acceptLicense = true;
          };
        };
      in rec {
        devShells = {
          default = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              ##################
              ### VULKAN SDK ###
              vulkan-headers
              vulkan-loader
              vulkan-validation-layers
              vulkan-tools
              vulkan-tools-lunarg
              vulkan-utility-libraries
              vulkan-extension-layer
              vulkan-volk
              vulkan-validation-layers
              spirv-headers
              spirv-tools
              spirv-cross
              mesa
              glslang
              ##################

              ####################
              ### Compat Tools ###
              xorg.libX11
              xorg.libXrandr
              xorg.libXcursor
              xorg.libXi
              xorg.libXxf86vm
              xorg.libXinerama
              wayland
              wayland-protocols
              kdePackages.qtwayland
              kdePackages.wayqt
              ####################

              #################
              ### Libraries ###
              glfw3
              glm
              #################

              #################
              ### Compilers ###
              shaderc
              gcc
              clang
              #################
              zig
            ];

            packages = with pkgs; [
              (writeShellApplication {
                name = "compile-shaders";
                text = ''
                  exec ${shaderc.bin}/bin/glslc shader.vert -o vert.spv &
                  exec ${shaderc.bin}/bin/glslc shader.frag -o frag.spv &
                  exec ${shaderc.bin}/bin/glslc point.vert -o point.vert.spv &
                  exec ${shaderc.bin}/bin/glslc point.frag -o point.frag.spv
                '';
              })
              (writeShellApplication {
                ## Lets renderdoc run on wayland using xwayland
                name = "renderdoc";
                text = "QT_QPA_PLATFORM=xcb env -u WAYLAND_DISPLAY qrenderdoc";
              })

              #############
              ### Langs ###
              zig
              #############

              #############
              ### Tools ###
              cmake
              renderdoc
              #############
            ];

            LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
            VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            VULKAN_SDK = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            XDG_DATA_DIRS = builtins.getEnv "XDG_DATA_DIRS";
            XDG_RUNTIME_DIR = "/run/user/1000";
            STB_INCLUDE_PATH = "./headers/stb";
          };
        };
      }
    );
}
