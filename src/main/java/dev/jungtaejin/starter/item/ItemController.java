package dev.jungtaejin.starter.item;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.net.URI;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Minimal CRUD surface so the deployment has something to health-check and hit
 * with a smoke test.  The interesting parts of this repo are in /infra and
 * /.github/workflows; the application itself is intentionally boring.
 */
@RestController
@RequestMapping("/api/items")
public class ItemController {

    private final ItemRepository repository;

    public ItemController(ItemRepository repository) {
        this.repository = repository;
    }

    public record ItemRequest(@NotBlank @Size(max = 100) String name) {
    }

    public record ItemResponse(Long id, String name, LocalDateTime createdAt) {
        static ItemResponse from(Item item) {
            return new ItemResponse(item.getId(), item.getName(), item.getCreatedAt());
        }
    }

    @GetMapping
    public List<ItemResponse> list() {
        return repository.findAll().stream().map(ItemResponse::from).toList();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ItemResponse> get(@PathVariable Long id) {
        return repository.findById(id)
                .map(item -> ResponseEntity.ok(ItemResponse.from(item)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ItemResponse> create(@Valid @RequestBody ItemRequest request) {
        Item saved = repository.save(new Item(request.name()));
        return ResponseEntity.created(URI.create("/api/items/" + saved.getId()))
                .body(ItemResponse.from(saved));
    }
}
