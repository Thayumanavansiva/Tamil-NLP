import { useState } from "react";
import "./App.css";
import MindMap from "./Mindmap";

export default function App() {
  const [messages, setMessages] = useState([
    { role: "assistant", content: "உங்கள் பத்தியை உள்ளிடுங்கள், மன வரைபடம் உருவாகும்!" },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false); // 🔑 New loading state

  const handleSend = async () => {
    if (!input.trim() || loading) return;

    const userMessage = { role: "user", content: input };
    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setLoading(true); 

    setMessages((prev) => [
      ...prev,
      { role: "assistant", content: "மனது வரைபடம் உருவாக்கப்படுகிறது..." },
    ]);

    try {
      const response = await fetch("http://127.0.0.1:8000/analyze", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: input }),
    });
      
      const data = await response.json();
      /*const data = {
      name: "மனப்பகர்வு வழிகாட்டிகள்",
      children: [
        { name: "தெளிவானது" },
        { name: "மையம்" },
        { name: "பாணி" },
        { name: "பயன்பாடு" },
        { name: "முக்கிய சொற்கள்" },
        { name: "வரிகள்" },
      ],
    };*/
      setMessages((prev) => [
        ...prev.slice(0, -1), 
        { role: "assistant", content: <MindMap data={data} /> },
      ]);
    } catch (error) {
      console.error("Error fetching mind map:", error);
      setMessages((prev) => [
        ...prev.slice(0, -1),
        {
          role: "assistant",
          content: "மனது வரைபடம் உருவாக்க முடியவில்லை. இது ஏற்பட்டதற்கு வருந்துகிறோம்.",
        },
      ]);
    } finally {
      setLoading(false); // 🔓 Unlock input
    }
  };

  return (
    <div className="chat-container dark">
      <header className="chat-header">
        <h1>மன வரைபடம் உருவாக்கி</h1>
      </header>

      <div className="chat-messages">
        {messages.map((msg, idx) => (
          <div key={idx} className={`message-wrapper ${msg.role}`}>
            <div className={`message ${msg.role}`}>
              {typeof msg.content === "string" ? (
                msg.content
              ) : (
                <div className="mindmap-wrapper">{msg.content}</div>
              )}
            </div>
          </div>
        ))}
      </div>

      <div className="chat-input">
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Type a message..."
          onKeyDown={(e) => e.key === "Enter" && handleSend()}
          disabled={loading} 
        />
        <button onClick={handleSend} disabled={loading}>
          {loading ? "Generating..." : "Send"}
        </button>
      </div>
    </div>
  );
}
