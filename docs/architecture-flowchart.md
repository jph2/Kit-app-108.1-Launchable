# Launchable Isaac Lab / Isaac Sim Stack Flowchart

```mermaid
flowchart TD
    User[Browser User]
    subgraph Browser
        Viewer["Web Viewer (Vite React app)\n/ viewer"]
        VSCodeUI["VS Code UI via nginx\n/ lab"]
    end

    subgraph NGINX[NGINX Reverse Proxy]
        ProxyTLS["TLS Termination\n+ Token Handoff"]
    end

    subgraph Containers[Docker Compose Stack]
        subgraph VSCode[VS Code Container]
            CodeServer["code-server\n(port 8080)"]
            Workspace[/Workspace Files/]
        end
        subgraph ViewerContainer[Web Viewer Container]
            ViteServer["Vite Dev Server\n(port 5173)"]
            ConfigRewrite["Entry Script\nRewrite stream.config.json"]
        end
        subgraph IsaacServices[Isaac Runtime]
            IsaacLab["Isaac Lab\nKit App"]
            IsaacSim["Isaac Sim\nKit App"]
            Composer["Omniverse Composer\nKit App"]
            WebRTC["Omniverse WebRTC\nPlugin"]
            AppStreamAPI["App Streaming REST API"]
        end
        SharedCaches[("Omniverse\nCache Volumes")]
    end

    subgraph Host[GPU Host]
        Driver["NVIDIA Drivers"]
        Ports["Open Ports\n80, 1024, 47998, 49100"]
    end

    User --> Viewer
    Viewer -->|HTTPS| ProxyTLS
    VSCodeUI -->|HTTPS| ProxyTLS
    ProxyTLS -->|/viewer| ViteServer
    ProxyTLS -->|/ lab & /| CodeServer

    ViteServer --> ConfigRewrite
    ConfigRewrite --> AppStreamAPI

    IsaacLab --> WebRTC
    IsaacSim --> WebRTC
    Composer --> WebRTC
    WebRTC --> AppStreamAPI

    AppStreamAPI --> WebRTC
    WebRTC -->|Media Streams| Viewer

    CodeServer --> Workspace
    IsaacLab --> Workspace
    IsaacSim --> Workspace
    Composer --> Workspace

    Containers --> SharedCaches
    IsaacLab -->|GPU Access| Driver
    IsaacSim -->|GPU Access| Driver
    Composer -->|GPU Access| Driver
    Driver --> IsaacLab
    Driver --> IsaacSim
    Driver --> Composer
    IsaacLab --> Ports
    IsaacSim --> Ports
    Composer --> Ports
    Ports --> Viewer
```

This diagram outlines the key services, how they are orchestrated via Docker Compose, and the interaction path from the end user through the nginx proxy to the Isaac applications and WebRTC streaming components.
