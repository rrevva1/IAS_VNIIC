import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class RunPgSqlFile {
    private static String jdbcUrl(String host, String port, String dbName) {
        String encodedDb = dbName.replace(" ", "%20");
        return "jdbc:postgresql://" + host + ":" + port + "/" + encodedDb;
    }

    private static String quoteIdent(String ident) {
        return "\"" + ident.replace("\"", "\"\"") + "\"";
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 7) {
            System.err.println("Usage: RunPgSqlFile <host> <port> <admin_db> <user> <target_db> <script_path> <password>");
            System.exit(2);
        }

        String host = args[0];
        String port = args[1];
        String adminDb = args[2];
        String user = args[3];
        String targetDb = args[4];
        String scriptPath = args[5];
        String password = args[6];

        Class.forName("org.postgresql.Driver");

        try (Connection adminConn = DriverManager.getConnection(jdbcUrl(host, port, adminDb), user, password)) {
            boolean exists;
            try (PreparedStatement ps = adminConn.prepareStatement("SELECT 1 FROM pg_database WHERE datname = ?")) {
                ps.setString(1, targetDb);
                try (ResultSet rs = ps.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (!exists) {
                String createSql = "CREATE DATABASE " + quoteIdent(targetDb) + " WITH ENCODING 'UTF8' TEMPLATE template0";
                try (Statement st = adminConn.createStatement()) {
                    st.execute(createSql);
                }
                System.out.println("Database created: " + targetDb);
            } else {
                System.out.println("Database already exists: " + targetDb);
            }
        }

        String script = Files.readString(Path.of(scriptPath), StandardCharsets.UTF_8);
        StringBuilder filtered = new StringBuilder();
        for (String line : script.split("\\R")) {
            String trimmed = line.trim();
            if (!trimmed.startsWith("\\")) {
                filtered.append(line).append(System.lineSeparator());
            }
        }

        try (Connection targetConn = DriverManager.getConnection(jdbcUrl(host, port, targetDb), user, password);
             Statement st = targetConn.createStatement()) {
            st.execute(filtered.toString());
            System.out.println("Schema script executed: " + scriptPath);
        }

        List<String> requiredTables = Arrays.asList(
                "roles", "permissions", "users", "user_roles", "role_permissions",
                "locations", "dic_equipment_status", "dic_task_status",
                "equipment", "equip_history", "spr_parts", "spr_chars", "part_char_values",
                "tasks", "task_history", "task_equipment",
                "desk_attachments", "task_attachments",
                "audit_events", "import_runs", "import_errors", "nsi_change_log"
        );

        Set<String> existing = new HashSet<>();
        try (Connection targetConn = DriverManager.getConnection(jdbcUrl(host, port, targetDb), user, password);
             PreparedStatement ps = targetConn.prepareStatement(
                     "SELECT table_name FROM information_schema.tables WHERE table_schema = 'tech_accounting'"
             );
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                existing.add(rs.getString(1));
            }
        }

        boolean ok = true;
        for (String table : requiredTables) {
            if (!existing.contains(table)) {
                ok = false;
                System.err.println("Missing table: " + table);
            }
        }

        if (!ok) {
            System.exit(1);
        }

        System.out.println("Validation passed. Required tables are present.");
    }
}
