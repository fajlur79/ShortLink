(function() {
    'use strict';

    const API_BASE = window.APP_CONFIG.apiBase;
    let currentToken = null;

    const elements = {
        urlInput: document.getElementById('urlInput'),
        shortenBtn: document.getElementById('shortenBtn'),
        generateTokenBtn: document.getElementById('generateTokenBtn'),
        copyUrlBtn: document.getElementById('copyUrlBtn'),
        copyTokenBtn: document.getElementById('copyTokenBtn'), // New
        result: document.getElementById('result'),
        shortUrl: document.getElementById('shortUrl'),
        alert: document.getElementById('alert'),
        newTokenReveal: document.getElementById('newTokenReveal'), // New
        tokenValue: document.getElementById('tokenValue'), // New
        sessionBadge: document.getElementById('sessionBadge'), // New
        urlsShortened: document.getElementById('urlsShortened'),
        urlsLimit: document.getElementById('urlsLimit')
    };

    async function init() {
        setupEventListeners();
        await checkExistingToken(); // Silently checks
        await loadUsageStats();
    }

    function setupEventListeners() {
        elements.generateTokenBtn.addEventListener('click', handleGenerateToken);
        elements.shortenBtn.addEventListener('click', handleShortenUrl);
        elements.copyUrlBtn.addEventListener('click', () => copyToClipboard(elements.shortUrl, elements.copyUrlBtn));
        elements.copyTokenBtn.addEventListener('click', () => copyToClipboard(elements.tokenValue, elements.copyTokenBtn));
        elements.urlInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') handleShortenUrl();
        });
    }

    // Check for existing token (SILENT - Does not show UI)
    async function checkExistingToken() {
        try {
            const response = await fetchAPI('/get-key', { method: 'GET' });
            if (response.ok) {
                const data = await response.json();
                if (data.token) {
                    currentToken = data.token;
                    updateSessionState(true);
                }
            }
        } catch (error) {
            console.error('Error checking token:', error);
        }
    }

    // Generate new token (LOUD - Shows UI)
    async function handleGenerateToken() {
        setButtonLoading(elements.generateTokenBtn, true, 'Generating...');
        
        // Hide previous results
        elements.newTokenReveal.style.display = 'none';

        try {
            const response = await fetchAPI('/generate-key', { method: 'POST' });
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to generate token');
            }

            const data = await response.json();
            currentToken = data.token;
            
            // 1. Show the "One Time Reveal" box
            showNewToken(data.token);
            
            // 2. Update Badge
            updateSessionState(true);
            
            // 3. Refresh Stats (to check for the limit warning)
            await loadUsageStats();

        } catch (error) {
            showAlert(error.message, 'error');
        } finally {
            setButtonLoading(elements.generateTokenBtn, false, 'Get New API Token');
        }
    }

    async function handleShortenUrl() {
        const url = elements.urlInput.value.trim();
        if (!url) return showAlert('Please enter a URL', 'error');
        
        if (!currentToken) {
            return showAlert('No active session. Please click "Get New API Token" first.', 'error');
        }

        setButtonLoading(elements.shortenBtn, true, 'Shortening...');

        try {
            const response = await fetchAPI('/shorten', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-api-key': currentToken
                },
                body: JSON.stringify({ url })
            });

            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to shorten URL');
            }

            const data = await response.json();
            showResult(data.shortUrl);
            elements.urlInput.value = '';
            await loadUsageStats();
        } catch (error) {
            showAlert(error.message, 'error');
        } finally {
            setButtonLoading(elements.shortenBtn, false, 'Shorten');
        }
    }

    async function loadUsageStats() {
        try {
            const response = await fetchAPI('/usage', { method: 'GET' });
            if (response.ok) {
                const data = await response.json();
                updateStats(data);
            }
        } catch (error) {
            console.error('Error loading stats:', error);
        }
    }

    function updateStats(data) {
        // Update URL Counters
        elements.urlsShortened.textContent = data.limits.shortening.used;
        elements.urlsLimit.textContent = data.limits.shortening.limit;

        // Check Token Limit for Popup Warning
        const tokenStats = data.limits.tokenGeneration.device;
        const remainingTokens = tokenStats.limit - tokenStats.used;

        if (remainingTokens === 1) {
             showAlert("⚠️ Warning: You have only 1 token generation left for today!", "warning");
        }
    }

    // UI Helpers
    function updateSessionState(isActive) {
        elements.sessionBadge.style.display = isActive ? 'inline-block' : 'none';
    }

    function showNewToken(token) {
        elements.tokenValue.textContent = token;
        elements.newTokenReveal.style.display = 'block';
        showAlert("Token generated! Copy it now.", "success");
    }

    function showResult(shortUrl) {
        elements.shortUrl.value = shortUrl;
        elements.result.classList.add('show');
    }

    // Robust Copy Function (Works on Mobile/HTTP)
    async function copyToClipboard(inputElementOrText, button) {
        const text = inputElementOrText.value || inputElementOrText.textContent;
        
        // Helper to trigger success animation
        const showSuccess = () => {
            const originalText = button.innerHTML;
            button.innerHTML = '<i class="fa-solid fa-check"></i>';
            button.classList.add('copied');
            setTimeout(() => {
                button.innerHTML = originalText;
                button.classList.remove('copied');
            }, 2000);
        };

        try {
            // 1. Try Modern API (Works on HTTPS)
            if (navigator.clipboard && window.isSecureContext) {
                await navigator.clipboard.writeText(text);
                showSuccess();
            } else {
                // 2. Fallback for Mobile/HTTP (The "Old School" way)
                const textArea = document.createElement("textarea");
                textArea.value = text;
                
                // Ensure it's not visible but part of the DOM
                textArea.style.position = "fixed";
                textArea.style.left = "-9999px";
                textArea.style.top = "0";
                document.body.appendChild(textArea);
                
                textArea.focus();
                textArea.select();
                
                const successful = document.execCommand('copy');
                document.body.removeChild(textArea);
                
                if (successful) {
                    showSuccess();
                } else {
                    throw new Error("Fallback copy failed");
                }
            }
        } catch (err) {
            console.error("Copy failed:", err);
            showAlert('Press and hold the link to copy manually.', 'warning');
        }
    }

    function showAlert(message, type) {
        elements.alert.textContent = message;
        elements.alert.className = `alert alert-${type} show`;
        setTimeout(() => elements.alert.classList.remove('show'), 5000);
    }

    function setButtonLoading(button, isLoading, text) {
        button.disabled = isLoading;
        button.innerHTML = isLoading ? `${text} <span class="loading"></span>` : text;
    }

    async function fetchAPI(endpoint, options = {}) {
        return fetch(`${API_BASE}${endpoint}`, { credentials: 'include', ...options });
    }

    document.addEventListener('DOMContentLoaded', init);
})();