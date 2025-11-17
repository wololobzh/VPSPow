import express from "express";
import jwt from "jsonwebtoken";
import cookieParser from "cookie-parser";

const app = express();
app.use(express.json());
app.use(cookieParser());

const JWT_SECRET = "xxxxxxxCHANGE_ME_SECRET_32_CHARS";

app.post("/auth/login", (req, res) => {
    const { username, password } = req.body;

    if (username !== "admin" || password !== "test") {
        return res.status(401).json({ error: "Invalid credentials" });
    }

    const token = jwt.sign({ user: username }, JWT_SECRET, { expiresIn: "1h" });
    res.cookie("token", token, { httpOnly: true });
    return res.json({ success: true });
});

app.get("/auth/verify", (req, res) => {
    const token = req.cookies.token;

    if (!token) return res.status(401).send("no token");

    try {
        jwt.verify(token, JWT_SECRET);
        return res.status(200).send("ok");
    } catch {
        return res.status(401).send("invalid");
    }
});

app.listen(4000, () => console.log("Auth server running on 4000"));
