const tabButtons = document.querySelectorAll('.tab-btn');
const tabPanels = document.querySelectorAll('.tab-panel');

function activateTab(tabName) {
    tabButtons.forEach((button) => {
        const isActive = button.dataset.tab === tabName;
        button.classList.toggle('is-active', isActive);
        button.setAttribute('aria-selected', String(isActive));
    });

    tabPanels.forEach((panel) => {
        const isActive = panel.id === `tab-${tabName}`;
        panel.classList.toggle('is-active', isActive);
    });
}

tabButtons.forEach((button) => {
    button.addEventListener('click', () => activateTab(button.dataset.tab));
});
