import express from "express";
import jwt from "jsonwebtoken";
import cookieParser from "cookie-parser";

const app = express();
app.use(express.json());
app.use(cookieParser());

const JWT_SECRET = "xxxxxxxCHANGE_ME_SECRET_32_CHARS";

app.post("/auth/login", (req, res) => {
    const { username, password } = req.body;

    // EXEMPLE : tes utilisateurs en dur (peut être déplacé en DB ensuite)
    const USERS = {
        admin: { password: "test", role: "admin" },
        alice: { password: "test", role: "user" }
    };

    const user = USERS[username];
    if (!user || user.password !== password) {
        return res.status(401).json({ error: "Invalid credentials" });
    }

    // ---- JWT avec rôle ----
    const token = jwt.sign(
      { user: username, role: user.role },
      JWT_SECRET,
      { expiresIn: "2h" }
    );

    res.cookie("token", token, { httpOnly: true });
    res.json({ success: true });
});

app.get("/auth/verify", (req, res) => {
    const token = req.cookies.token;
    if (!token) return res.status(401).send("no token");

    try {
        const decoded = jwt.verify(token, JWT_SECRET);

        // Rôle requis envoyé par nginx
        const requiredRole = req.headers["x-required-role"];

        if (requiredRole && decoded.role !== requiredRole) {
            return res.status(403).send("forbidden");
        }

        return res.status(200).send("ok");
    } catch {
        return res.status(401).send("invalid");
    }
});


app.listen(4000, () => console.log("Auth server running on 4000"));
