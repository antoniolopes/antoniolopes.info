// Check if dark mode is enabled
const isDarkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
var mainBlock = document.getElementById("main");
if (isDarkMode) {
	mainBlock.classList.add("darkmode");
}