(function () {
    /** Simple Markdown: **bold**, *italic*, [text](url), and newlines (double = paragraph). Output is safe HTML. */
    function markdownToHtml(text) {
        if (!text || typeof text !== 'string') return '';
        var s = text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
        s = s.replace(/\[([^\]]*)\]\(([^)]*)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
        s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
        s = s.replace(/\*([^*]+)\*/g, '<em>$1</em>');
        s = s.replace(/\n\n+/g, '</p><p>');
        s = s.replace(/\n/g, '<br>');
        return '<p>' + s + '</p>';
    }

    function run(config) {
        config = config || {};
        var welcomeEl = document.getElementById('welcome-title');
        if (welcomeEl && config.welcomeMessage) {
            welcomeEl.textContent = config.welcomeMessage;
        }
        var rulesEl = document.getElementById('rules-content');
        if (rulesEl && config.rulesContent) {
            rulesEl.innerHTML = markdownToHtml(config.rulesContent);
        }
        var newsEl = document.getElementById('latest-news-content');
        if (newsEl && config.latestNewsContent) {
            newsEl.innerHTML = markdownToHtml(config.latestNewsContent);
        }

        var progressFill = document.getElementById('progress-fill');
    const progressText = document.getElementById('progress-text');
    const backgroundEl = document.getElementById('background');

    function setProgress(fraction) {
        const percent = Math.round((fraction || 0) * 100);
        if (progressFill) progressFill.style.width = percent + '%';
        if (progressText) progressText.textContent = percent + '%';
    }

    window.addEventListener('message', function (event) {
        const data = event.data;
        if (data.eventName === 'loadProgress' && typeof data.loadFraction === 'number') {
            setProgress(data.loadFraction);
        }
    });

    if (backgroundEl) {
        const bgImg = new Image();
        bgImg.onload = function () {
            backgroundEl.setAttribute('data-loaded', 'true');
        };
        bgImg.src = 'assets/background.png';
    }

    setProgress(0);

    var radioAudio = document.getElementById('radio-audio');
    var radioToggle = document.getElementById('radio-toggle');
    var radioVolume = document.getElementById('radio-volume');
    var radioStatus = document.getElementById('radio-status');
    var radioModule = document.querySelector('.radio-module');

    if (radioAudio && radioToggle && radioModule) {
        radioAudio.volume = (radioVolume ? parseInt(radioVolume.value, 10) / 100 : 25 / 100);

        radioToggle.addEventListener('click', function () {
            if (radioAudio.paused) {
                radioModule.classList.remove('is-playing');
                radioModule.classList.add('is-loading');
                radioStatus.textContent = 'Connecting…';
                radioAudio.play().then(function () {
                    radioModule.classList.remove('is-loading');
                    radioModule.classList.add('is-playing');
                    radioStatus.textContent = 'Live';
                }).catch(function () {
                    radioModule.classList.remove('is-loading');
                    radioStatus.textContent = 'Error';
                });
            } else {
                radioAudio.pause();
                radioModule.classList.remove('is-playing', 'is-loading');
                radioStatus.textContent = 'Paused';
            }
        });

        radioAudio.addEventListener('playing', function () {
            radioModule.classList.remove('is-loading');
            radioModule.classList.add('is-playing');
            radioStatus.textContent = 'Live';
        });
        radioAudio.addEventListener('pause', function () {
            radioModule.classList.remove('is-playing', 'is-loading');
            radioStatus.textContent = 'Paused';
        });
        radioAudio.addEventListener('error', function () {
            radioModule.classList.remove('is-loading', 'is-playing');
            radioStatus.textContent = 'Error';
        });

        if (radioVolume) {
            radioVolume.addEventListener('input', function () {
                radioAudio.volume = parseInt(radioVolume.value, 10) / 100;
            });
        }

        radioModule.classList.add('is-loading');
        radioStatus.textContent = 'Connecting…';
        radioAudio.play().then(function () {
            radioModule.classList.remove('is-loading');
            radioModule.classList.add('is-playing');
            radioStatus.textContent = 'Live';
        }).catch(function () {
            radioModule.classList.remove('is-loading');
            radioStatus.textContent = 'Paused';
        });
    }
    }

    fetch('config.json')
        .then(function (r) { return r.json(); })
        .then(run)
        .catch(function () { run({}); });
})();
