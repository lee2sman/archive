const container = document.getElementsByClassName('grid-container')[0];
const items = Array.from(container.children);
const originalOrder = [...items];

function randomizeOrder() {
    const items = Array.from(container.children);
    // Shuffle array
    for (let i = items.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [items[i], items[j]] = [items[j], items[i]];
    }
    
    // Re-append in new order
    items.forEach(item => container.appendChild(item));
}

function sortAlphabetical() {
    const items = Array.from(container.children);
    // Sort by text content (A-Z)
    items.sort((a, b) => 
        a.textContent.toLowerCase().localeCompare(b.textContent.toLowerCase())
    );
    
    // Re-append in sorted order
    items.forEach(item => container.appendChild(item));
}

function restoreOriginalOrder() {
 const currentItems = Array.from(container.children);
    currentItems.forEach(item => item.remove());
    
    // Add back in original order
    originalOrder.forEach(item => container.appendChild(item));
}

function goToRandomLink() {
    // Get all anchor tags with href attributes
    const links = document.querySelectorAll('a[href]');
    
    // Get random link
    const randomLink = links[Math.floor(Math.random() * links.length)];
    const randomHref = randomLink.href;
    
    // Navigate to it
    window.location.href = randomHref;
}
