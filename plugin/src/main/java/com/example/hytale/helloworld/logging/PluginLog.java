package com.example.hytale.helloworld.logging;

import com.hypixel.hytale.logger.HytaleLogger;
import com.hypixel.hytale.server.core.plugin.JavaPlugin;

/**
 * Tiny helper to keep the plugin's root logger and common sub-loggers together.
 */
public final class PluginLog {
    private final HytaleLogger root;
    private final HytaleLogger lifecycle;

    private PluginLog(HytaleLogger root) {
        this.root = root;
        this.lifecycle = root.getSubLogger("Lifecycle");
    }

    public static PluginLog forPlugin(JavaPlugin plugin, String componentName) {
        HytaleLogger base = plugin.getLogger().getSubLogger(componentName);
        return new PluginLog(base);
    }

    public HytaleLogger root() {
        return root;
    }

    public HytaleLogger lifecycle() {
        return lifecycle;
    }

    public HytaleLogger sub(String name) {
        return root.getSubLogger(name);
    }

    public void info(String message, Object... args) {
        root.atInfo().log(message, args);
    }

    public void warn(String message, Object... args) {
        root.atWarning().log(message, args);
    }

    public void error(String message, Object... args) {
        root.atSevere().log(message, args);
    }
}
