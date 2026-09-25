package com.example.bankapp;

import org.junit.jupiter.api.Test;
import org.yaml.snakeyaml.LoaderOptions;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.Reader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThatCode;

class ManifestSyntaxTests {

    @Test
    void yamlFilesAreSyntacticallyValid() throws IOException {
        List<Path> roots = List.of(Path.of("k8s"), Path.of("helm"), Path.of(".github"));

        for (Path root : roots) {
            try (Stream<Path> paths = Files.walk(root)) {
                paths.filter(Files::isRegularFile)
                    .filter(this::isYaml)
                    .forEach(this::assertValidYaml);
            }
        }

        assertValidYaml(Path.of("docker-compose.yml"));
        assertValidYaml(Path.of("k8s", "bankapp-secret.yml.example"));
    }

    private boolean isYaml(Path path) {
        String name = path.getFileName().toString();
        return name.endsWith(".yml") || name.endsWith(".yaml");
    }

    private void assertValidYaml(Path path) {
        assertThatCode(() -> {
            LoaderOptions options = new LoaderOptions();
            options.setAllowDuplicateKeys(false);
            Yaml yaml = new Yaml(options);
            try (Reader reader = Files.newBufferedReader(path)) {
                yaml.loadAll(reader).forEach(document -> { });
            }
        }).as("YAML syntax in %s", path).doesNotThrowAnyException();
    }
}
